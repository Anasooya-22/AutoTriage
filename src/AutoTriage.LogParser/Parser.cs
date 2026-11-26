using System.Text.RegularExpressions;

namespace AutoTriage.LogParser;

public record LogEntry(DateTime Time, string Level, string Source, string Message);

public static class Parser
{
    private static readonly Regex Rx = new(
        @"^(?<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) \[(?<level>\w+)\] \[(?<src>[^\]]+)\] (?<msg>.*)$");

       public static LogEntry? ParseLine(string line)
    {
        if (string.IsNullOrWhiteSpace(line)) return null;
        var m = Rx.Match(line);
        if (!m.Success) return null;
        if (!DateTime.TryParse(m.Groups["ts"].Value, out var time)) return null;
        return new LogEntry(
            time,
            m.Groups["level"].Value,
            m.Groups["src"].Value,
            m.Groups["msg"].Value);
    }
}