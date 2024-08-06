# odoo-openupgrade-migrate-sh
This is a collection of scripts to try to migrate an Odoo database from a major
version to its next major version.
These scripts are meant to be ran on a local environment or migration computer.

## Requirements
### 1. Local Installation and Setup of PostgreSQL
You need to have PostgreSQL installed and set up on your local machine (or migration computer).

#### For Ubuntu/Debian:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

#### For macOS (using Homebrew):
```bash
brew update
brew install postgresql
brew services start postgresql
```

#### For Windows:
Download the installer from the official PostgreSQL website (https://www.postgresql.org/download/windows/) and follow the installation instructions.

### 2. Restore Backup of the Database to Migrate
#### 1. Create odoo user
```bash
sudo -i -u postgres
createuser odoo -s -r -d -P
```
    or executing the SQL statement:
```postgresql
CREATE ROLE odoo WITH PASSWORD 'odoo' SUPERUSER CREATEROLE CREATEDB LOGIN;
```

#### 2. Create a new database for your Odoo instance:
```bash
createdb your_database_name -O odoo
```
or executing the SQL statement:
```postgresql
CREATE database WITH OWNER odoo;
```

#### 3. Restore Database Backup from Dump File
```bash
psql -h localhost -Uodoo -d your_database_name < dump.sql
```
Alternatively to steps 2 and 3 above, you could copy the dump.sql file to the project <b>backup</b> folder and reply yes when the script prompts:
```bash
Do you want to restore the database from a dump file? (y/n)
```
<b>IMPORTANT</b>: If you are migrating several versions you should always reply N after the first migration or you will loose previous migrations


### 3. Create .env File:

In the project directory create a ``` .env ``` file with the following environment variables:
```bash
# PostgreSQL Connection Info
DB_HOST=your_database_host
DB_PORT=your_database_port
DB_USER=odoo
DB_NAME=your_database_name
DB_PASSWORD=your_db_user_password

# Inventory
ODOO_INVENTORY_REPO=project_inventory_repo
ODOO_INVENTORY_BRANCH=project_inventory_repo_branch
```

### 4. Install Pyenv
pyenv is used to manage multiple Python versions. Install and set up pyenv on your local machine by following the steps below:

#### For Ubuntu/Debian:

```bash
curl https://pyenv.run | bash
```

Add the following lines to your .bashrc or .zshrc file (or create a .bash_profile):

```bash
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

Restart your shell:

```bash
exec "$SHELL"
```

#### For macOS (using Homebrew):

```bash
brew update
brew install pyenv
Add the following lines to your .bash_profile or .zshrc file:
```
```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

Restart your shell:

```bash
exec "$SHELL"
```



## Usage
Execute the main script and pass the next (major) odoo version to the one the is currently on (e.g. 13.0 if the database is on 12.0).
```bash
./migrate_odoo_db.sh <major_odoo_version>
```
During execution if a ```.bash_profile``` script is found a prompt asking if to execute it will show, in case pyenv is not globally enabled.

After the extra addons requirements update, the scrip will also pause until the user decides. This allows missing dependency resolution.
