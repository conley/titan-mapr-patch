conf = new BaseConfiguration();
conf.setProperty("storage.backend","hbase");
conf.setProperty("storage.hostname","REPLACEME");
conf.setProperty("storage.tablename","DESIREDTABLENAME")
g = TitanFactory.open(conf);
