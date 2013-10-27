# titan-mapr-patch #

Deploy titan server on MapR.

## Idea for bulk loading ##

Let's take Whois as an example. Here's the proposed procedure for bulk-loading into titan:

1. Run a Spark job on the input data. This should parse the data and then create two RDDs which should be saved to HDFS. Let's just screw it for now and write in in GraphSON. This means each line should correspond to a vertex, followed by the edges.
2. Run a Faunus job with GraphSON as input and Titan-HBase as output to write the graph into Titan.

