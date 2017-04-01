import argparse
import os
import sys
from jinja2 import Environment, PackageLoader, FileSystemLoader


def get_arguments():
    parser = argparse.ArgumentParser(description='Generate a configuration.')
    parser.add_argument('networkName', metavar='networkName', type=str, help='Configuration name')
    parser.add_argument('networkPath', metavar='networkPath', type=str, help='Configuration name')
    parser.add_argument('templateFile', metavar='templateFile', type=str, help='Template filename')

    parser.add_argument("--density-aware", dest="density_aware", action='store_true',
                        help="Generate density aware map.")

    args = parser.parse_args()
    return args


def generate_simple_config(network_path, network_name, template_file):
    path, filename = os.path.split(template_file)
    env = Environment(
        loader=FileSystemLoader(path or './'),
        autoescape=False
    )

    template = env.get_template(filename)
    config = template.render()
    print config


def generate_density_aware_config(network_path, network_name, template_file):
    path, filename = os.path.split(template_file)
    env = Environment(
        loader=FileSystemLoader(path or './'),
        autoescape=False
    )

    denisty_file = network_path + network_name + ".density"
    if not os.path.isfile(denisty_file):
        sys.stderr.write("\tCouldn't find density file: {}\n".format(denisty_file))
        sys.exit(1)
    with open(denisty_file, "r") as text_file:
        lines = [line.strip().split(',') for line in text_file.readlines()]

    class Node:
        def __init__(self, name, density):
            self.name = name
            self.density = density

        def algorithm(self):
            return "mprt2" if self.density < 10 else "abba2"

    nodes = [Node(line[0].strip(), int(line[1].strip())) for line in lines]

    template = env.get_template(filename)
    print template.render(nodes=nodes)

if __name__ == '__main__':
    args = get_arguments()

    if args.density_aware:
        generate_density_aware_config(args.networkPath, args.networkName, args.templateFile)
    else:
        generate_simple_config(args.networkPath, args.networkName, args.templateFile)
