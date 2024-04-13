from pyspark.sql import SparkSession

def main():
    spark = SparkSession.builder.appName("WordCount").getOrCreate()
    text_file = spark.sparkContext.textFile("/files/book.txt")
    
    counts = text_file.flatMap(lambda line: line.split(" ")) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)
    
    counts.saveAsTextFile("output")
    spark.stop()

if __name__ == "__main__":
    main()
