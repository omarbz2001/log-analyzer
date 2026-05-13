enum LogLevel with Eq, ToString {
    case Error
    case Warn
    case Info
    case Debug
}

enum LogEntry {
    case LogEntry(String, LogLevel, String)
    // LogEntry(timestamp, level, message)
}

enum LogSummary {
    case LogSummary(Int32, Int32, Int32, Int32)
    // LogSummary(errors, warns, infos, debugs)
}