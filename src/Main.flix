def main(): Unit \ {Chan, NonDet, IO} = region rc {
    let totalLines = 20;

    let (rawTx, rawRx) = Channel.buffered(10);
    let (parsedTx, parsedRx) = Channel.buffered(10);

    spawn producer(rawTx) @ rc;
    spawn parserStage(rawRx, parsedTx, totalLines) @ rc;

    let summary = aggregatorStage(parsedRx);
    println(Aggregator.report(summary))
}

// IO removed from effect — List.forEach + Channel.send only needs Chan
def producer(tx: Sender[String]): Unit \ Chan =
    let lines =
        "2026-05-13 ERROR Database connection failed" ::
        "2026-05-13 INFO User alice logged in"        ::
        "2026-05-13 WARN High memory usage"           ::
        "2026-05-13 DEBUG Heartbeat tick"             ::
        "2026-05-13 ERROR Disk full"                  ::
        "2026-05-13 INFO User bob logged out"         ::
        "2026-05-13 WARN CPU usage above 90 percent"  ::
        "2026-05-13 ERROR Null pointer exception"     ::
        "2026-05-13 INFO Backup completed"            ::
        "2026-05-13 DEBUG Cache cleared"              ::
        "2026-05-13 WARN Slow query detected"         ::
        "2026-05-13 ERROR Service timeout"            ::
        "2026-05-13 INFO Scheduled job started"       ::
        "2026-05-13 DEBUG Config reloaded"            ::
        "2026-05-13 WARN Retry attempt three"         ::
        "2026-05-13 ERROR Out of memory"              ::
        "2026-05-13 INFO New connection accepted"     ::
        "2026-05-13 DEBUG Thread pool resized"        ::
        "2026-05-13 WARN Deprecated API called"       ::
        "2026-05-13 INFO Shutdown initiated"          ::
        Nil;
    List.forEach(line -> Channel.send(line, tx), lines)

def parserStage(rx: Receiver[String], tx: Sender[Option[LogEntry]], n: Int32): Unit \ {Chan, NonDet} =
    if (n <= 0)
        Channel.send(None, tx)
    else {
        let rawLine = Channel.recv(rx);
        match Parser.parseLine(rawLine) {
            case Some(entry) =>
                if (Classifier.keep(entry)) {
                    Channel.send(Some(entry), tx);
                    parserStage(rx, tx, n - 1)
                } else
                    parserStage(rx, tx, n - 1)
            case None =>
                parserStage(rx, tx, n - 1)
        }
    }

def aggregatorStage(rx: Receiver[Option[LogEntry]]): LogSummary \ {Chan, NonDet} =
    aggregatorLoop(rx, Aggregator.empty())

def aggregatorLoop(rx: Receiver[Option[LogEntry]], acc: LogSummary): LogSummary \ {Chan, NonDet} =
    match Channel.recv(rx) {
        case None        => acc
        case Some(entry) => aggregatorLoop(rx, Aggregator.add(acc, entry))
    }