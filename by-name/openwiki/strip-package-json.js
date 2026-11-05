const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json"));
delete pkg.devDependencies;
delete pkg.scripts;
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
