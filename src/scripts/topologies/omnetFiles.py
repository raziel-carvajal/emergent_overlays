from jinja2 import Environment, PackageLoader


def createNedFile(denType, pos, index, layoutSizeW, layoutSizeH, Tx, callback_source):
    networkName = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}_p_".format(len(pos), denType, Tx, layoutSizeW, layoutSizeH, index)
    fileName = networkName + ".ned"

    class Net:
        def __init__(self, name, w, h, positions):
            self.name = name
            self.w = w
            self.h = h
            self.pos = positions
            self.positions = range(0, len(pos))

        def node_info(self, idx):
            p = self.pos[idx]
            s = callback_source(idx, p)
            return str('{}'.format(s))

    env = Environment(
        loader=PackageLoader('omnetFiles', ''),
        autoescape=False
    )

    template = env.get_template('topology.template')
    config = template.render(network=Net(networkName, layoutSizeW, layoutSizeH, pos))
    with open(fileName, "w") as text_file:
        text_file.write("{0}".format(config))


def create_density_file(generated_densities, w, h, density, Tx, index):
    fileName = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}_p_.density".format(len(generated_densities), density, Tx, w, h, index)
    with open(fileName, "w") as text_file:
        text_file.writelines(["hostR{0}, {1}\n".format(idx, v) for idx, v in enumerate(generated_densities)])
    pass
