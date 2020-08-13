import ballerina/io;
import ballerina/log;
import ballerina/time;

function copy(io:ReadableByteChannel src, io:WritableByteChannel dst) returns error? {
    while (true) {
        byte[]|io:Error result = src.read(1000);
        if (result is io:EofError) {
            break;
        } else if (result is error) {
            return <@untainted>result;
        } else {
            int i = 0;
            while (i < result.length()) {
                var result2 = dst.write(result, i);
                if (result2 is error) {
                    return result2;
                } else {
                    i = i + result2;
                }
            }
        }
    }
    return;
}

function close(io:ReadableByteChannel|io:WritableByteChannel ch) {
    abstract object {
        public function close() returns error?;
    } channelResult = ch;
    var cr = channelResult.close();
    if (cr is error) {
        log:printError("Error occurred while closing the channel: ", cr);
    }
}

public function main() returns @tainted error? {
    string srcPath = "./src/byte/resources/ballerina.jpeg";
    string dstPath = "./src/byte/resources/ballerinaCopy.jpeg";

    io:ReadableByteChannel srcCh = check io:openReadableFile(srcPath);
    io:WritableByteChannel dstCh = check io:openWritableFile(dstPath);

    // Copying
    time:Time beforeCopy = time:currentTime();
    var result = copy(srcCh, dstCh);
    time:Time afterCopy = time:currentTime();
    time:Time timeDuration = time:subtractDuration(
        afterCopy, time:getYear(beforeCopy), 
        time:getMonth(beforeCopy), 
        time:getDay(beforeCopy), 
        time:getHour(beforeCopy), 
        time:getMinute(beforeCopy), 
        time:getSecond(beforeCopy), 
        time:getMilliSecond(beforeCopy)
    );
    io:println("Byte copy time duration: ", time:getMilliSecond(timeDuration), "ms");
    close(srcCh);
    close(dstCh);
}
