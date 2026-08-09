import pathlib, re
files = [
    "ruby.api/MigrationScripts/V1_0_0__CreateMasterReferenceTables.sql",
    "ruby.api/MigrationScripts/V1_0_1__CreateOperationTables.sql"
]
pattern = re.compile(r'"([A-Za-z0-9_]+)"')
for file in files:
    path = pathlib.Path(file)
    text = path.read_text(encoding='utf-8')
    new_text = pattern.sub(lambda m: m.group(1).lower(), text)
    path.write_text(new_text, encoding='utf-8')
    print(f'updated {file}')
