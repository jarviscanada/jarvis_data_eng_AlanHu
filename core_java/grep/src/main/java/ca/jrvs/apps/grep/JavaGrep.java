package ca.jrvs.apps.grep;

import java.io.File;
import java.io.IOException;
import java.util.List;

public interface JavaGrep {
  /**
   * top level search workflow
   * @throws IOException if something goes wrong
   */
  void process() throws IOException;

  /**
   * traverse a directory and return all files
   * @param rootDir input directory
   * @return files within root directory
   */
  List<File> listFiles(String rootDir);

  /**
   * read a file and return all lines
   * @param inputFile file to be read
   * @return lines
   * @throws IllegalArgumentException if param inputFile is not a file
   */
  List<String> readLines(File inputFile) throws IllegalArgumentException;

  /**
   * check if a line contains regex pattern, pattern passed through user input
   * @param line line to check
   * @return true if the line contains the pattern, false if not
   */
  boolean containsPattern(String line);

  /**
   * writes lines to file (set by outFile variable)
   * @param lines matched lines
   * @throws IOException if write fails
   */
  void writeToFile(List<String> lines) throws IOException;

  /**
   * will fetch the root path from cli input
   * @return the root path as a string
   */
  String getRootPath();

  /**
   * will set the root path as a variable within our main method
   * @param rootPath user root directory from which the program operates
   */
  void setRootPath(String rootPath);

  /**
   * gets specified pattern from cli input
   * @return the pattern as a string
   */
  String getRegex();

  /**
   * sets the pattern using cli input
   * @param regex
   */
  void setRegex(String regex);

  /**
   * gets the output file from cli input
   * @return the output file as a string
   */
  String getOutFile();

  /**
   * sets the output file
   * @param outFile output file as a string
   */
  void setOutFile(String outFile);
}
