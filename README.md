# CoEditPDF-api
API for CoEditPDF application.
## Run
1. Clone this repository
```
git clone https://github.com/ccaq-2019/CoEditPDF-api.git
cd CoEditPDF-api
```
2. Install the dependencies (except for pg)
```
bundle install --without production
```
3. Copy and rename `config/secrets.example.yml` to `config/secrets.yml` and set all the config variables.
4. Setup the database
```
rake db:migrate
```
5. Run the API on localhost
```
rake run:dev
```
