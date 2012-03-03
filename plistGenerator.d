#!/usr/local/bin/rdmd
module plistGenerator;import std.stdio, std.conv, std.algorithm, std.string;import std.stream, std.xml, std.regex, std.file;private string[] keywords;private string[] specialTokens;private string[] phobosModules;private string plistHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict>  <key>keywords</key>  <array>";private string plistKeywords = "    <dict>      <key>description</key>      <string>control structures, general keywords</string>      <key>color</key>      <string>KeywordColor</string>      <key>strings</key>      <dict>
";// closes off plistKeywords <dict> <dict>
private string plistSpecialTokens = "      </dict>    </dict>    <dict>      <key>description</key>      <string>special tokens</string>      <key>color</key>      <string>PreprocessorColor</string>      <key>strings</key>      <dict>
";    // closes off plistSpecialTokens <dict> <dict>  
private string plistPhobos = "       </dict>     </dict>     <dict>       <key>description</key>       <string>phobos modules</string>       <key>color</key>       <string>ClassColor</string>       <key>strings</key>       <dict>
";    // closes off the header's <array> and plistPhobos <dict> <dict>
private string plistBlocks = "      </dict>    </dict>     </array> <key>ranges</key><dict><key>BlockComment</key><dict><key>color</key><string>CommentColor</string><key>end</key><string>*/</string><key>start</key><string>/*</string></dict><key>NestedBlockComment</key><dict><key>color</key><string>CommentColor</string><key>end</key><string>+/</string><key>start</key><string>/+</string></dict>		<key>DoubleQuote</key><dict><key>color</key><string>StringColor</string><key>end</key><string>&quot;</string>								<key>escape</key><string>\\</string><key>start</key><string>&quot;</string></dict><key>ReDoubleQuote</key><dict><key>color</key><string>StringColor</string><key>end</key><string>&quot;</string><key>escape</key><string>\\</string><key>start</key><string>r&quot;</string></dict>									<key>OneLineComment</key><dict><key>color</key><string>CommentColor</string><key>end</key><string>
</string><key>start</key><string>#!</string></dict><key>OneLineComment2</key><dict><key>color</key><string>CommentColor</string><key>end</key><string>
</string><key>start</key><string>//</string></dict>	</dict><key>numbers</key><dict><key>color</key><string>NumberColor</string><key>pattern</key><string>(?&lt;=[^\\w\\d]|^)(((([0-9]+\\.[0-9]*)|(\\.[0-9]+))([eE][+\\-]?[0-9]+)?[fFlL]?)|((([1-9][0-9]*)|0[0-7]*|(0[xX][0-9a-fA-F]+))(([uU][lL]?)|([lL][uU]?))?))(?=[^\\w\\d]|$)</string></dict><key>completions</key><array><dict><key>word</key><string>for ()</string><key>insertion</key><string>for (&lt;!#expressions#!&gt;) {}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict><dict><key>word</key><string>foreach ()</string><key>insertion</key><string>foreach (&lt;!#expressions#!&gt;) {}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict>	<dict><key>word</key><string>foreach_reverse ()</string><key>insertion</key><string>foreach_reverse (&lt;!#expressions#!&gt;) {}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict>			<dict><key>word</key><string>if ()</string><key>insertion</key><string>if (&lt;!#condition#!&gt;) {}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict><dict><key>word</key><string>if () else {}</string><key>insertion</key><string>if (&lt;!#condition#!&gt;) {} else {}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict><dict><key>word</key><string>else if ()</string><key>insertion</key><string>else if (&lt;!#condition#!&gt;) {}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict><dict><key>word</key><string>else {}</string><key>insertion</key><string>else {&lt;!##!&gt;}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict><dict><key>word</key><string>while ()</string><key>insertion</key><string>while (&lt;!#condition#!&gt;) {}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict><dict><key>word</key><string>do {} while ()</string><key>insertion</key><string>do {} while (&lt;!#condition#!&gt;);</string><key>prefix</key><string>all</string><key>completion</key><true/></dict><dict><key>word</key><string>switch ()</string><key>insertion</key><string>switch (&lt;!#expression#!&gt;) {default:break;}</string><key>prefix</key><string>all</string><key>completion</key><true/></dict>";// closes <array> from blocks and headers <dict><plist>
private string plistFooter = "</array><key>wordCharacters</key><string>_</string></dict></plist>";string plistWrap(string key) {    return "        <key>" ~ key ~ "</key>\n        <string></string>\n";  }void main(){    string[] deprecatedModules = ["std.cpuid", "std.ctype", "std.date", "std.gregorian", "std.regexp"];    string dlangOrgStd = "/Users/joshuaniehus/GIT/d-programming-language.org/std.ddoc";
    string dlangOrgLex = "/Users/joshuaniehus/GIT/d-programming-language.org/lex.dd";
    auto ddStdDoc = std.stdio.File(dlangOrgStd, "r");
    auto ddLexDoc = std.stdio.File(dlangOrgLex, "r");
    
    foreach(string line; lines(ddStdDoc)) {
        auto m = match(line, regex(r"(>[a-z]{1,99}\.[a-z0-9]{1,99}</a>\))|(>[a-z]{1,99}\.[a-z0-9]{1,99}\.[a-z0-9]{1,99}</a>\))"));
        if (m) {
            string phobosModule = m.hit()[1 .. $-5]; // shave off the > and the </a>)
            if (find(deprecatedModules, phobosModule) == []) {
                phobosModules ~= phobosModule;
            }
        }
    }
    
    foreach(string line; lines(ddLexDoc)) {
        auto k = match(line, regex(r"\$\(B\s+([a-z]{2,99}|[a-z]{2,99}_[a-z]{1,99}|__[A-Za-z]{1,99})\)"));
        auto t = match(line, regex(r"CODE\s+__[A-Z]{1,99}__\)"));
        if (k) {
            string[] splitKeyword = std.array.split(k.hit());
            keywords ~= splitKeyword[1][0 .. $-1];
        }
        
        if (t) {
            string[] splitToken = std.array.split(t.hit());
            specialTokens ~= splitToken[1][0 .. $-1];
        }         
    }    // more special case keywords
    keywords ~= "string"; 
    keywords ~= "wstring"; 
    keywords ~= "dstring";     
    keywords ~= "size_t";
    keywords ~= "ptrdiff_t";
    keywords ~= "sizediff_t";
    keywords ~= "hash_t";
    keywords ~= "equals_t";  
    
    string plist = "";    plist ~= plistHeader;    plist ~= plistKeywords;    foreach(string keyword; keywords) {        plist ~= plistWrap(keyword);    }    plist ~= plistSpecialTokens;    foreach(string token; specialTokens) {        plist ~= plistWrap(token);    }    plist ~= plistPhobos;    foreach(string phobosModule; phobosModules) {        plist ~= plistWrap(phobosModule);    }                plist ~= plistBlocks;    plist ~= plistFooter; 
    
    std.xml.check(plist);    
    std.stream.File f = new std.stream.File();
    f.create("dlang.plist");
    f.writeString(plist);
    writeln(plist);      }