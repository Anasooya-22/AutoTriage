
using AutoTriage.LogParser;

var cases = new (string Name, string Input, bool ExpectParsed, string? ExpectedLevel)[]
{
    ("Normal INFO line",  "2026-11-23 08:01:02 [INFO] [FileWatcher] User session opened", true, "INFO"),
    ("ERROR line",        "2026-11-23 08:00:20 [ERROR] [AuthService] Access denied to folder C:\\data\\secure", true, "ERROR"),
    ("Empty string",      "", false, null),
    ("Whitespace only",   "   ", false, null),
    ("Garbage text",      "this is not a real log file", false, null),
    ("Missing bracket",   "2026-11-23 08:01:02 [INFO [FileWatcher] msg", false, null),
    ("Impossible date",   "2026-13-45 99:99:99 [INFO] [X] msg", false, null),
};

int pass = 0, fail = 0;
foreach (var c in cases)
{
    bool ok;
    string result;
    try
    {
        var e = Parser.ParseLine(c.Input);
        bool parsed = e != null;
        ok = parsed == c.ExpectParsed && (!parsed || e!.Level == c.ExpectedLevel);
        result = parsed ? $"parsed ({e!.Level})" : "null";
    }
    catch (Exception ex)
    {
        ok = false;
        result = "EXCEPTION " + ex.GetType().Name;
    }
    Console.WriteLine($"{(ok ? "PASS" : "FAIL")} | {c.Name} | {result}");
    if (ok) pass++; else fail++;
}
Console.WriteLine($"\n{pass} passed, {fail} failed");
return fail > 0 ? 1 : 0;