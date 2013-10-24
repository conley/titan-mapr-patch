conf = new BaseConfiguration();
conf.setProperty("storage.backend","hbase");
conf.setProperty("storage.hostname","REPLACEME");
g = TitanFactory.open(conf);
