// --- Parser tests ---

@Test
def testParseLine_validError(): Bool =
    match Parser.parseLine("2026-05-13 ERROR Database failed") {
        case Some(_) => true
        case None    => false
    }

@Test
def testParseLine_validInfo(): Bool =
    match Parser.parseLine("2026-05-13 INFO User logged in") {
        case Some(_) => true
        case None    => false
    }

@Test
def testParseLine_malformed(): Bool =
    match Parser.parseLine("this is not valid") {
        case Some(_) => false
        case None    => true
    }

@Test
def testParseLine_unknownLevel(): Bool =
    match Parser.parseLine("2026-05-13 CRITICAL Something") {
        case Some(_) => false
        case None    => true
    }

// --- Classifier tests ---

@Test
def testClassifier_keepError(): Bool =
    Classifier.keep(LogEntry.LogEntry("2026-05-13", LogLevel.Error, "msg"))

@Test
def testClassifier_keepInfo(): Bool =
    Classifier.keep(LogEntry.LogEntry("2026-05-13", LogLevel.Info, "msg"))

@Test
def testClassifier_dropDebug(): Bool =
    not Classifier.keep(LogEntry.LogEntry("2026-05-13", LogLevel.Debug, "msg"))

@Test
def testClassifier_isAlert_error(): Bool =
    Classifier.isAlert(LogEntry.LogEntry("2026-05-13", LogLevel.Error, "msg"))

@Test
def testClassifier_isAlert_warn(): Bool =
    not Classifier.isAlert(LogEntry.LogEntry("2026-05-13", LogLevel.Warn, "msg"))

// --- Aggregator tests ---

@Test
def testAggregator_emptyIsZero(): Bool =
    let LogSummary.LogSummary(e, w, i, d) = Aggregator.empty();
    e == 0 and w == 0 and i == 0 and d == 0

@Test
def testAggregator_addError(): Bool =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Error, "msg"));
    let LogSummary.LogSummary(e, _, _, _) = summary;
    e == 1

@Test
def testAggregator_addWarn(): Bool =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Warn, "msg"));
    let LogSummary.LogSummary(_, w, _, _) = summary;
    w == 1

@Test
def testAggregator_addInfo(): Bool =
    let summary = Aggregator.add(Aggregator.empty(), LogEntry.LogEntry("ts", LogLevel.Info, "msg"));
    let LogSummary.LogSummary(_, _, i, _) = summary;
    i == 1