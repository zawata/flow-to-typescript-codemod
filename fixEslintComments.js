/* eslint-disable */

const fs = require('fs');
const { EOL } = require("os");

const dir = process.argv[2];

const files = fs.globSync([
  `${dir}/**/*.js`,
  `${dir}/**/*.jsx`,
  `${dir}/**/*.ts`,
  `${dir}/**/*.tsx`
]);

const ignoredDirectories = [
    'node_modules/',
    'flow-typed/',
    'dist/',
    'out/',
    'resources/',
    'temp/'
];

for(const filename of files) {
    if (ignoredDirectories.some(dir => filename.includes(dir))) {
        continue;
    }

    let contents = null;
    try {
        contents = fs.readFileSync(filename, 'utf8');
        console.log('running:', filename);
    } catch(e) {
        console.log('error:', filename, e);
        continue;
    }

    if (!contents) {
        console.log('no contents:', filename);
        continue;
    }

    const lines = contents.split(EOL);
    const isJsx = filename.endsWith('.jsx') || filename.endsWith('.tsx');

    const outputContents = [];
    for(let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if(line.includes('// eslint-disable-line')) {
            let [
                code,
                suppression
            ] = line.split('// eslint-disable-line', 2);

            // get indentation level of code
            const indentation = code.match(/^\s*/)[0];
            code = code.trimEnd();
            suppression = suppression.trim();

            if (code.startsWith(`${indentation}<`) && isJsx && i > 0 && (lines[i-1].endsWith('>') || lines[i-1].endsWith('}'))) {
                outputContents.push(indentation + '{/* eslint-disable-next-line ' + suppression + ' */}');
            } else {
                outputContents.push(indentation + '// eslint-disable-next-line ' + suppression);
            }

            outputContents.push(code);
        } else {
            outputContents.push(line);
        }
    }

    fs.writeFileSync(filename, outputContents.join(EOL), 'utf8');
}