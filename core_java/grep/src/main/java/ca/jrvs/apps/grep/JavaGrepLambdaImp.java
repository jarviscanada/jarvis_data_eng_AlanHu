package ca.jrvs.apps.grep;

// import packages
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import org.slf4j.LoggerFactory;
import org.slf4j.Logger;

public class JavaGrepLambdaImp extends JavaGrepImp {

  public static void main(String[] args) {
    if (args.length != 3) {
      throw new IllegalArgumentException("Incorrect number of program parameters. Please provide the regex pattern, root directory, and output file");
    }

    JavaGrepLambdaImp javaGrepLambdaImp = new JavaGrepLambdaImp();
    javaGrepLambdaImp.setRegex(args[0]);
    javaGrepLambdaImp.setRootPath(args[1]);
    javaGrepLambdaImp.setOutFile(args[2]);

//    try catch block with overridden methods
    try {
      javaGrepLambdaImp.process();
    } catch (IOException e) {
      javaGrepLambdaImp.logger.error("Error, unable to complete process", e);
    }
  }

//  implement using lambdas and stream API
  @Override
  public List<String> readLines(File inputFile) {
    if (inputFile == null || !inputFile.isFile()) {
      throw new IllegalArgumentException("Input parameter is not a file or is null");
    }

    try {
      return Files.lines(inputFile.toPath())
          .collect(Collectors.toList());
    } catch (IOException e) {
      throw new RuntimeException("Issue when reading file: ", e);
    }
  }


  @Override
  public List<File> listFiles(String rootDir) {
//    recursively walk through current directory and subdirectory
//    retrieve only regular files -> openable
//    map path objects to file objects
//    convert to arraylist
    try {
      return Files.walk(Paths.get(rootDir))
          .filter(Files::isRegularFile)
          .map(Path::toFile)
          .collect(Collectors.toCollection(ArrayList::new));
    } catch (IOException e) {
      throw new RuntimeException("Failed to traverse directory: " + rootDir, e);
    }
  }
}
