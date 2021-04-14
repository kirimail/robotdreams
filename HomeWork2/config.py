import yaml
import os


def load_config(env="dev"):
    """
    Returns python config
    :param env: specify environment. i.e. prod
    :return:
    """
    try:
        with open(os.path.join(os.getcwd(), "", "config.yaml")) as config_file:
            config = yaml.safe_load(config_file)[env]
        return config
    except KeyError:
        return KeyError(f"No such environment - {env} in config file.")