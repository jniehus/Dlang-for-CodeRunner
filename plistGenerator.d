#!/usr/local/bin/rdmd

";
private string plistSpecialTokens = "
";
private string plistPhobos = "
";    
private string plistBlocks = "
</string>
</string>
private string plistFooter = "</array>
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
    }
    keywords ~= "string"; 
    keywords ~= "wstring"; 
    keywords ~= "dstring";     
    keywords ~= "size_t";
    keywords ~= "ptrdiff_t";
    keywords ~= "sizediff_t";
    keywords ~= "hash_t";
    keywords ~= "equals_t";  
    
    string plist = "";
    
    std.xml.check(plist);    
    std.stream.File f = new std.stream.File();
    f.create("dlang.plist");
    f.writeString(plist);
    writeln(plist);      