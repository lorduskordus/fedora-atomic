function getDefaultExportFromCjs (x) {
	return x && x.__esModule && Object.prototype.hasOwnProperty.call(x, 'default') ? x['default'] : x;
}

/*
Language: Shell Session
Requires: bash.js
Author: TSUYUSATO Kitsune <make.just.on@gmail.com>
Category: common
Audit: 2020
*/

var shell_1;
var hasRequiredShell;

function requireShell () {
	if (hasRequiredShell) return shell_1;
	hasRequiredShell = 1;
	/** @type LanguageFn */
	function shell(hljs) {
	  return {
	    name: 'Shell Session',
	    aliases: [
	      'console',
	      'shellsession'
	    ],
	    contains: [
	      {
	        className: 'meta.prompt',
	        // We cannot add \s (spaces) in the regular expression otherwise it will be too broad and produce unexpected result.
	        // For instance, in the following example, it would match "echo /path/to/home >" as a prompt:
	        // echo /path/to/home > t.exe
	        begin: /^\s{0,3}[/~\w\d[\]()@-]*[>%$#][ ]?/,
	        starts: {
	          end: /[^\\](?=\s*$)/,
	          subLanguage: 'bash'
	        }
	      }
	    ]
	  };
	}

	shell_1 = shell;
	return shell_1;
}

var shellExports = requireShell();
const shell = /*@__PURE__*/getDefaultExportFromCjs(shellExports);

export { shell as default };
