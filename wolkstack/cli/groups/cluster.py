import click

# Command Group
@click.group(name='cluster')
def cluster():
    """Manage the deployed kubernetes cluster."""
    pass


@cluster.command(name='install', help='test install')
@click.option('--test1', default='1', help='test option')
def install_cmd(test1):
    click.echo('Hello world')


@cluster.command(name='search', help='test search')
@click.option('--test1', default='1', help='test option')
def search_cmd(test1):
    click.echo('Hello world')


if __name__ == '__main__':
    cluster()
