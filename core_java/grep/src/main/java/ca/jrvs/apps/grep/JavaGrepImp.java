package ca.jrvs.apps.grep;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.stream.Collectors;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import org.apache.log4j.BasicConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JavaGrepImp implements JavaGrep{
//  declare root path, pattern, output file variables
  private String regex;
  private String rootPath;
  private String outFile;

//  declare logger object
  final Logger logger = LoggerFactory.getLogger(JavaGrep.class);

  @Override
  public void process() throws IOException {
    ArrayList<String> matchedLines = new ArrayList<String>();
    for (File file : listFiles(this.getRootPath())) {
      for (String line : readLines(file)) {
        if (containsPattern(line)) {
          matchedLines.add(line);
        }
      }
    }
    writeToFile(matchedLines);
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

  @Override
  public List<String> readLines(File inputFile) {
//    handle case where inputFile is not a file or null
    if (inputFile == null || !inputFile.isFile() ) {
      throw new IllegalArgumentException("Input parameter is not a file or is null");
    }

//    create list to store lines
    ArrayList<String> fileLines = new ArrayList<String>();

//    iterate through and read file line by line
//    use resources to automatically ditch resources after method/loop is finished running

    try (BufferedReader bufferReader = new BufferedReader(new FileReader(inputFile))) {
      String line;
      while ((line = bufferReader.readLine()) != null) {
        fileLines.add(line);
      }
    }
    catch (IOException e) {
      throw new RuntimeException("Issue when creating buffer to read file: ", e);
    }
    return fileLines;
  }

  @Override
  public boolean containsPattern(String line) {
//    check for regex pattern within the line
    Pattern pattern = Pattern.compile(this.getRegex());
    Matcher matcher = pattern.matcher(line);

    return matcher.find();

  }

  @Override
  public void writeToFile(List<String> lines) {
    try (
    FileOutputStream outputStream = new FileOutputStream(this.getOutFile());
    OutputStreamWriter streamWriter = new OutputStreamWriter(outputStream, StandardCharsets.UTF_8);
    BufferedWriter bw = new BufferedWriter(streamWriter);
        )
    {
      for (String line : lines) {
        bw.write(line);
        bw.newLine();
//        don't forget newline to write line by line
      }
    }
    catch (IOException e) {
      throw new RuntimeException("Problem writing to file (file possibly does not exist)", e);
    }
  }

  @Override
  public String getRootPath() {
    return this.rootPath;
  }

  @Override
  public void setRootPath(String rootPath) {
    this.rootPath = rootPath;
  }

  @Override
  public String getRegex() {
    return this.regex;
  }

  @Override
  public void setRegex(String pattern) {
    this.regex = pattern;
  }

  @Override
  public String getOutFile() {
    return this.outFile;
  }

  @Override
  public void setOutFile(String outFile) {
    this.outFile = outFile;
  }

  public static void main(String[] args) {
//    throw an error if there are not exactly three arguments
    if (args.length != 3) {
      throw new IllegalArgumentException("Incorrect number of program parameters. Please provide the regex pattern, root directory, and output file");
    }

    BasicConfigurator.configure();

//    now run the process method

//    but first we need to fetch the input parameters
    JavaGrepImp imp = new JavaGrepImp();
    imp.setRegex(args[0]);
    imp.setRootPath(args[1]);
    imp.setOutFile(args[2]);

    try {
      imp.process();
    }
    catch (IOException e) {
      imp.logger.error("Error: unable to complete process", e);
    }
  }
}
