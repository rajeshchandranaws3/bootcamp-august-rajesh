import requests
from requests.auth import HTTPBasicAuth

username = 'rajeshchandranaws3'
PAT = 'ghp_YourPersonalAccessTokenHere'


def list_github_public_repos(username):
    github_api_url = f"https://api.github.com/users/{username}/repos"
    response = requests.get(github_api_url, params={"type": "public"})
    repos = response.json()
    for repo in repos:
        print(f"Name: {repo['name']}")
        print(f"URL: {repo['html_url']}")

print("---- Listing Public Repositories ----")
list_github_public_repos(username)

def create_github_repo(repo_name, description="", private=False, token=""):
    github_api_url = "https://api.github.com/user/repos"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    data = {
        "name": repo_name,
        "description": description,
        "private": private
    }
    response = requests.post(github_api_url, json=data, headers=headers)
    print(response.json())
# print("---- Creating a New Repository ----")
# create_github_repo("dumdum", description="dumdum repo", private=False, token=PAT)

def delete_github_repo(repo_name, token=""):
    github_api_url = f"https://api.github.com/repos/{username}/{repo_name}"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    response = requests.delete(github_api_url, headers=headers)
    if response.status_code == 204:
        print(f"Repository '{repo_name}' deleted successfully.")
    else:
        print(f"Failed to delete repository '{repo_name}'. Status code: {response.status_code}")
        print(response.json())

print("---- Deleting a Repository ----")
delete_github_repo("dumdum", token=PAT)