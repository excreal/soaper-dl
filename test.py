import requests
from bs4 import BeautifulSoup

# Fetch HTML from the Go downloads page
url = 'https://go.dev/dl/'
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

# Get the latest version block (it's the first .toggleVisible div)
latest_block = soup.select_one('div.toggleVisible')
if not latest_block:
    print("Could not find latest Go version section.")
    exit()

# Extract version name
version = latest_block.select_one('h3 span')
print("Latest Go Version:", version.text.strip() if version else "Unknown")

# Extract download files and URLs
print("\nAvailable Downloads:")
for row in latest_block.select('table.downloadtable tbody tr'):
    filename_cell = row.select_one('td.filename a.download')
    os_cell = row.select_one('td:nth-of-type(3)')
    arch_cell = row.select_one('td:nth-of-type(4)')
    if filename_cell:
        download_url = "https://go.dev" + filename_cell['href']
        print(f"- {filename_cell.text.strip()} ({os_cell.text.strip()} {arch_cell.text.strip()}): {download_url}")
