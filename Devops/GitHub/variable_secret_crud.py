import requests
import json
import csv
from base64 import b64encode
from nacl import encoding, public
import os

base_dir = os.path.dirname(os.path.abspath(__file__)).replace('\\', '/')

# read json config file
with open(f'{base_dir}/github_setup_config.json', 'r') as f:
    config = json.load(f)

# Note that Organization variables and secrets are not yet supported in this codebase

# Assume owner, repo, and environment_name are predefined for simplicity. Adjust as needed.
owner = config['owner']
repo = config['repo']
environment_name = config['environment_name']

token = config['github_pat']  # this is personal access token


# Headers must include your actual GitHub token
headers = {
    'Accept': 'application/vnd.github+json',
    'Authorization': f'Bearer {token}',
    'X-GitHub-Api-Version': '2022-11-28',
    'Content-Type': 'application/x-www-form-urlencoded',
}


# Variables: #######################
# data = '{"name":"USERNAME","value":"octocat"}'


# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28

# Create repository variable:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#create-a-repository-variable
def create_repository_variable(owner, repo, headers, data):
    """Create a repository variable."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/variables'
    response = requests.post(url, headers=headers, data=data)
    print(f'Created {data["name"]} variable.')
    return response


# Create environment variable:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#create-an-environment-variable
def create_environment_variable(owner, repo, environment_name, headers, data):
    """Create an environment variable."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/variables'
    response = requests.post(url, headers=headers, data=data)
    print(f'Created {data["name"]} variable.')
    return response


# List repository variables:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#list-repository-variables
def list_repository_variables(owner, repo, headers):
    """List repository variables."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/variables'
    response = requests.get(url, headers=headers)
    return response


# List environment variables:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#list-environment-variables
def list_environment_variables(owner, repo, environment_name, headers):
    """List environment variables."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/variables'
    response = requests.get(url, headers=headers)
    return response


# Update repository variable:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#update-a-repository-variable
def update_repository_variable(owner, repo, name, headers, data):
    """Update a repository variable."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/variables/{name}'
    response = requests.patch(url, headers=headers, data=data)
    print(f'Updated {name} variable.')
    return response


# Update environment variable:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#update-an-environment-variable
def update_environment_variable(owner, repo, environment_name, name, headers, data):
    """Update an environment variable."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/variables/{name}'
    response = requests.patch(url, headers=headers, data=data)
    print(f'Updated {name} variable.')
    return response


# Delete repository variable:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#delete-a-repository-variable
def delete_repository_variable(owner, repo, name, headers):
    """Delete a repository variable."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/variables/{name}'
    response = requests.delete(url, headers=headers)
    print(f'Deleted {name} variable.')
    return response


# Delete environment variable:
# https://docs.github.com/en/rest/actions/variables?apiVersion=2022-11-28#delete-an-environment-variable
def delete_environment_variable(owner, repo, environment_name, name, headers):
    """Delete an environment variable."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/variables/{name}'
    response = requests.delete(url, headers=headers)
    print(f'Deleted {name} variable.')
    return response


# Secrets:
# data = '{"encrypted_value":"c2VjcmV0","key_id":"012345678912345678"}'


def encrypt(public_key: str, secret_value: str) -> str:
    """Encrypt a Unicode string using the public key."""
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return b64encode(encrypted).decode("utf-8")


# get public keys
# get repository public key
def get_repository_public_key(owner, repo, headers):
    """Get the repository public key."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/secrets/public-key'
    response = requests.get(url, headers=headers)
    return response


# get environment public key
def get_environment_public_key(owner, repo, environment_name, headers):
    """Get the environment public key."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/secrets/public-key'
    response = requests.get(url, headers=headers)
    return response


# https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28

# Create/update repository secret:
# https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#create-or-update-a-repository-secret
def create_update_repository_secret(owner, repo, secret_name, headers, data):
    """Create or update a repository secret."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/secrets/{secret_name}'
    response = requests.put(url, headers=headers, data=data)
    print(f'Created or updated {secret_name} secret.')
    return response


# Create/update environment secret:
# https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#create-or-update-an-environment-secret
def create_update_environment_secret(owner, repo, environment_name, secret_name, headers, data):
    """Create or update an environment secret."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/secrets/{secret_name}'
    response = requests.put(url, headers=headers, data=data)
    print(f'Created or updated {secret_name} secret.')
    return response


# List repository secrets:
# https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#list-repository-secrets
def list_repository_secrets(owner, repo, headers):
    """List repository secrets."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/secrets'
    response = requests.get(url, headers=headers)
    return response


# List environment secrets:
# https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#list-environment-secrets
def list_environment_secrets(owner, repo, environment_name, headers):
    """List environment secrets."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/secrets'
    response = requests.get(url, headers=headers)
    return response


# Delete repository secret:
# https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#delete-a-repository-secret
def delete_repository_secret(owner, repo, secret_name, headers):
    """Delete a repository secret."""
    url = f'https://api.github.com/repos/{owner}/{repo}/actions/secrets/{secret_name}'
    response = requests.delete(url, headers=headers)
    print(f'Deleted {secret_name} secret.')
    return response


# Delete environment secret:
# https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#delete-an-environment-secret
def delete_environment_secret(owner, repo, environment_name, secret_name, headers):
    """Delete an environment secret."""
    url = f'https://api.github.com/repos/{owner}/{repo}/environments/{environment_name}/secrets/{secret_name}'
    response = requests.delete(url, headers=headers)
    print(response.text)
    return response


def main():
    # Initialize containers for CSV data
    csv_data = []

    # Process CSV to categorize each entry
    # TODO update path
    with open(f'{base_dir}/github_variables_secrets.csv', mode='r', encoding='utf-8') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            csv_data.append(row)

    # Fetch existing variables and secrets for comparison
    # Assume functions returning JSON arrays of {'name': '...', 'value': '...'} for variables
    # and {'name': '...', 'encrypted_value': '...'} for secrets
    existing_repo_vars = json.loads(list_repository_variables(owner, repo, headers).text).get('variables', [])
    existing_env_vars = json.loads(list_environment_variables(owner, repo, environment_name, headers).text).get(
        'variables', [])
    existing_repo_secrets = json.loads(list_repository_secrets(owner, repo, headers).text).get('secrets', [])
    existing_env_secrets = json.loads(list_environment_secrets(owner, repo, environment_name, headers).text).get(
        'secrets', [])

    # Convert lists to dictionaries for easier name-based access
    existing_repo_vars_dict = {var['name']: var for var in existing_repo_vars}
    existing_env_vars_dict = {var['name']: var for var in existing_env_vars}
    existing_repo_secrets_dict = {secret['name']: secret for secret in existing_repo_secrets}
    existing_env_secrets_dict = {secret['name']: secret for secret in existing_env_secrets}

    # Process each entry in the CSV data
    for row in csv_data:
        # row = csv_data[1]  # for testing
        name, value, is_secret, level = row['Name'], row['Value'], row['IsSecret'] == '1', row['Level']

        # Handle creation or updating of repository or environment variables/secrets
        if is_secret:
            # Fetch appropriate public key for encryption
            if level.lower() == 'repository':
                public_key_response = get_repository_public_key(owner, repo, headers).json()
            elif level.lower() == 'environment':
                public_key_response = get_environment_public_key(owner, repo, environment_name, headers).json()
            else:
                continue  # Invalid level

            encrypted_value = encrypt(public_key_response['key'], value)
            data = json.dumps({"encrypted_value": encrypted_value, "key_id": public_key_response['key_id']})

            if level.lower() == 'repository':
                create_update_repository_secret(owner, repo, name, headers, data)
                # if name.upper() in existing_repo_secrets_dict:
                #     # Update if exists
                #     create_update_repository_secret(owner, repo, name, headers, data)
                # else:
                #     # Create if not exists
                #     create_update_repository_secret(owner, repo, name, headers, data)
            elif level.lower() == 'environment':
                create_update_environment_secret(owner, repo, environment_name, name, headers, data)
                # if name.upper() in existing_env_secrets_dict:
                #     # Update if exists
                #     create_update_environment_secret(owner, repo, environment_name, name, headers, data)
                # else:
                #     # Create if not exists
                #     create_update_environment_secret(owner, repo, environment_name, name, headers, data)
        else:
            data = json.dumps({"name": name, "value": value})
            if level.lower() == 'repository':
                if name.upper() not in existing_repo_vars_dict:
                    # Create if not exists
                    create_repository_variable(owner, repo, headers, data)
                else:
                    # Update if exists
                    update_repository_variable(owner, repo, name, headers, data)
            elif level.lower() == 'environment':
                if name.upper() not in existing_env_vars_dict:
                    # Create if not exists
                    create_environment_variable(owner, repo, environment_name, headers, data)
                else:
                    # Update if exists
                    update_environment_variable(owner, repo, environment_name, name, headers, data)

    # Sets to track what's supposed to exist according to the CSV
    csv_repo_vars_names = list(set(
        row['Name'].upper() for row in csv_data if row['Level'].lower() == 'repository' and row['IsSecret'] == '0'))
    csv_env_vars_names = list(set(
        row['Name'].upper() for row in csv_data if row['Level'].lower() == 'environment' and row['IsSecret'] == '0'))
    csv_repo_secrets_names = list(set(
        row['Name'].upper() for row in csv_data if row['Level'].lower() == 'repository' and row['IsSecret'] == '1'))
    csv_env_secrets_names = list(set(
        row['Name'].upper() for row in csv_data if row['Level'].lower() == 'environment' and row['IsSecret'] == '1'))

    # Deleting unlisted repository variables
    for existing_var in existing_repo_vars_dict.keys():
        if existing_var not in csv_repo_vars_names:
            delete_repository_variable(owner, repo, existing_var, headers)

    # Deleting unlisted environment variables
    for existing_var in existing_env_vars_dict.keys():
        if existing_var not in csv_env_vars_names:
            delete_environment_variable(owner, repo, environment_name, existing_var, headers)

    # Deleting unlisted repository secrets
    for existing_secret in existing_repo_secrets_dict.keys():
        if existing_secret not in csv_repo_secrets_names:
            delete_repository_secret(owner, repo, existing_secret, headers)

    # Deleting unlisted environment secrets
    for existing_secret in existing_env_secrets_dict.keys():
        if existing_secret not in csv_env_secrets_names:
            delete_environment_secret(owner, repo, environment_name, existing_secret, headers)


if __name__ == '__main__':
    main()
