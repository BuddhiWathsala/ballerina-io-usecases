import ballerina/io;
import ballerina/log;
import ballerina/time;

function closeRc(io:ReadableCharacterChannel rc) {
    var result = rc.close();
    if (result is error) {
        log:printError("Error occurred while closing character stream",
            err = result);
    }
}
function closeWc(io:WritableCharacterChannel wc) {
    var result = wc.close();
    if (result is error) {
        log:printError("Error occurred while closing character stream",
            err = result);
    }
}
function write(json content, string path) returns @tainted error? {
    io:WritableByteChannel wbc = check io:openWritableFile(path);
    io:WritableCharacterChannel wch = new (wbc, "UTF8");
    var result = wch.writeJson(content);
    closeWc(wch);
    return result;
}
function read(string path) returns @tainted json|error {
    io:ReadableByteChannel rbc = check io:openReadableFile(path);
    io:ReadableCharacterChannel rch = new (rbc, "UTF8");
    var result = rch.readJson();
    closeRc(rch);
    return result;
}

public function main() {
    string jsonReadFilePath = "./src/json/resources/files/read-file.json";
    string jsonWriteFilePath = "./src/json/resources/files/write-file.json";
    json content = {};

    // Reading
    time:Time beforeRead = time:currentTime();
    var readResult = read(jsonReadFilePath);
    time:Time afterRead = time:currentTime();
    time:Time readTimeDuration = time:subtractDuration(
        afterRead, time:getYear(beforeRead), 
        time:getMonth(beforeRead), 
        time:getDay(beforeRead), 
        time:getHour(beforeRead), 
        time:getMinute(beforeRead), 
        time:getSecond(beforeRead), 
        time:getMilliSecond(beforeRead)
    );
    if (readResult is json) {
        content = readResult;
        io:println("JSON read time duration: ", time:getMilliSecond(readTimeDuration), "ms");
    } else {
        log:printError("Error occurred while reading json: ", err = readResult);
    }

    // Writing
    time:Time beforeWrite = time:currentTime();
    var writeResult = write(content, jsonWriteFilePath);
    time:Time afterWrite = time:currentTime();
    time:Time writeTimeDuration = time:subtractDuration(
        afterWrite, time:getYear(beforeWrite), 
        time:getMonth(beforeWrite), 
        time:getDay(beforeWrite), 
        time:getHour(beforeWrite), 
        time:getMinute(beforeWrite), 
        time:getSecond(beforeWrite), 
        time:getMilliSecond(beforeWrite)
    );
    if (writeResult is json) {
        io:println("JSON write time duration: ", time:getMilliSecond(readTimeDuration), "ms");
    } else {
        log:printError("Error occurred while reading json: ", err = writeResult);
    }
}
