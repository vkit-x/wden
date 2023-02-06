'''
pip install -r tool/requirements.txt

fib tool/build_readme.py:build \
    --readme_md="./tool/README.md" \
    --main_yml="./.github/workflows/publish.yml" \
    --output="./README.md"
'''

import subprocess
import iolite as io
import yaml
import itertools


def combination(matrix):
    matrix.pop('include', None)
    excludes = matrix.pop('exclude', [])

    comb = []

    def dfs(keys, cur):
        skip = False
        for exclude in excludes:
            all_hit = True
            for ex_key, ex_val in exclude.items():
                if ex_key not in cur:
                    all_hit = False
                    break
                if cur[ex_key] != ex_val:
                    all_hit = False
                    break
            if all_hit:
                skip = True
                break

        if skip:
            print(f'skip {cur}')
            return

        if not keys:
            comb.append(cur.copy())
            return

        key = keys.pop()
        for val in matrix[key]:
            cur[key] = val
            dfs(keys, cur)
        cur.pop(key)
        keys.append(key)

    dfs(list(matrix.keys()), {})

    return comb


def build(readme_md, main_yml, output):
    assert readme_md != output
    template = io.file(readme_md, exists=True).read_text()

    # TOC.
    result = subprocess.run(
        [
            'markdown-toc',
            '-t',
            'github',
            '--no-write',
            readme_md,
        ],
        capture_output=True,
    )
    result.check_returncode()
    toc = result.stdout.decode().strip()

    template = template.replace('[TOC]', f'\n#{toc}\n')

    # Tables.
    config = yaml.safe_load(io.file(main_yml, exists=True).read_text())

    # CUDA.
    gpu_matrix = config['jobs']['build-cuda']['strategy']['matrix']
    gpu_comb = combination(gpu_matrix.copy())
    gpu_tag_cb = []
    for cb in gpu_comb:
        cuda_version = cb['cuda_version']
        cudnn_version = cb['cudnn_version']
        ubuntu_version = cb['ubuntu_version']
        python_version = cb['python_version']
        tag = f'devel-cuda{cuda_version}-cudnn{cudnn_version}-ubuntu{ubuntu_version}-python{python_version}'
        gpu_tag_cb.append((tag, cb))
    gpu_tag_cb = sorted(gpu_tag_cb, key=lambda p: p[0])

    # CPU.
    cpu_matrix = config['jobs']['build-cpu']['strategy']['matrix']
    cpu_comb = combination(cpu_matrix.copy())
    cpu_tag_cb = []
    for cb in cpu_comb:
        ubuntu_version = cb['ubuntu_version']
        python_version = cb['python_version']
        tag = f'devel-cpu-ubuntu{ubuntu_version}-python{python_version}'
        cpu_tag_cb.append((tag, cb))
    cpu_tag_cb = sorted(cpu_tag_cb, key=lambda p: p[0])

    def build_table(registry_prefix):
        table = [
            '| Construct | `docker pull` command |',
            '| --------- | -------------------- |',
        ]
        for tag, cb in itertools.chain(gpu_tag_cb, cpu_tag_cb):
            bases = []
            for key in sorted(cb):
                val = cb[key]
                if key.endswith('_version'):
                    key = key[:-len('_version')]
                key = key.upper()
                bases.append(f'{key}={val}')
            bases = ', '.join(bases)
            if not registry_prefix:
                table.append(f'| {bases} | `docker pull wden/wden:{tag}` |')
            else:
                table.append(f'| {bases} | `docker pull {registry_prefix}wden/wden:{tag} && docker tag {registry_prefix}wden/wden:{tag} wden/wden:{tag} ` |')
        return '\n'.join(table)

    table_docker_hub = build_table('')
    table_huaweicloud = build_table('swr.cn-east-3.myhuaweicloud.com/')

    template = template.replace('[TABLE_DOCKER_HUB]', f'\n{table_docker_hub}\n')
    template = template.replace('[TABLE_HUAWEICLOUD]', f'\n{table_huaweicloud}\n')

    io.file(output).write_text(template)
