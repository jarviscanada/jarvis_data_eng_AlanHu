# Introduction
This app provides an implementation of the `grep` linux command, implemented using Java and developed within IntelliJ. This app also allowed me to practice using Maven, an important product-level project build tool. To allow the app to be portable and used by anyone, anywhere, it was deployed as a Docker image that can be pulled and run locally.

# Quick Start
To use the app, head over to Docker Hub and pull the image, then run the app by providing the necessary parameters (pattern to search for, directory that contains files to search, output location):
<br>
```shell
  docker pull alanhu/grep
docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/log:/log \
  alanhu/grep ".*Romeo.*Juliet.*" /data /log/grep.out
```

# Implemenation
## Pseudocode
The pseudocode logic behind the `process` method is as follows:
```text
matchedLines = []
for file in listFiles(rootDir)
  for line in readLines(file)
      if containsPattern(line)
        matchedLines.add(line)
writeToFile(matchedLines)
```
We first use the `listFiles` method to generate a list of files present within `rootDir`. Then, we check for matches with the pattern provided within each line, and add matches to our `matchedLines` variable, which is then written to a file at the end.

## Performance Issue
The glaring performance issue here is: What happens if we run into extremely large files and/or an extremely large amount of files? This presents a memory issue as Java will attempt to read everything in at once. As such, we have provided a `JavaGrepLambdaImp` stream implementation of the app, which overrides two methods, `readLines` and `readFiles` and uses streams, which will read in one unit at a time, thus avoiding the memory issue, and providing a more efficient implementation as well.

# Test
To test the application, manual tests were ran locally, testing the functionality of the app. As mentioned in the **Improvements**
section, a possible next step would be to incorporate JUnit testing, making the code more robust by accounting for edge cases and unique inputs.
# Deployment
To make the app distributable, it was packaged using Maven and pushed as an image to the Docker Hub Registry. This way, people who are interested in using the app can do so regardless of their machine specifications, as long as they have Docker installed locally:
```shell
  cd core_java/grep
docker_user=your_docker_id
docker login -u ${docker_user} --password-stdin 

cat > Dockerfile << EOF
FROM openjdk:8-alpine
COPY target/grep*.jar /usr/local/app/grep/lib/grep.jar
ENTRYPOINT ["java","-jar","/usr/local/app/grep/lib/grep.jar"]
EOF

mvn clean package
docker build -t ${docker_user}/grep .

docker run --rm \
-v `pwd`/data:/data -v `pwd`/log:/log \
${docker_user}/grep .*Romeo.*Juliet.* /data /log/grep.out
docker push ${docker_user}/grep
```

# Improvement
1. Accept an arbitrary number of regex patterns to search for. This would allow the user to avoid having to run the app multiple times if they had multiple patterns. Each pattern would have its own output file, named accordingly.
2. Further modularize code by providing separate interfaces for file reading, file writing, etc. In doing so, we can perhaps make debugging our code easier -- if one chunk works, and so does the next, etc., then we can narrow down the source of our problems to a single block of code.
3. Even though unit testing was implemented for the practice stream implementation exercises, adding unit testing for the actual app itself could be a great next step. This tests edge cases, and will only help to make the code more robust.