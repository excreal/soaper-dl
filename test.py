import requests
from bs4 import BeautifulSoup

def get_latest_go_version():
    url = "https://go.dev/dl/"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    version_tag = soup.find("div", class_="download")
    if version_tag:
        version_text = version_tag.find("a").text.strip()
        return version_text
    return "Could not find Go version 😢"

latest_version = get_latest_go_version()
print(f"🚀 Latest Go version: {latest_version}")
