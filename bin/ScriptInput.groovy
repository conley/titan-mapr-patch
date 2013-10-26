def boolean read(FaunusVertex vertex, String line) {

    parts = line.split('\t');
    vertex.reuse(Long.valueOf(parts[0]))
    if (parts.length == 2) {
        parts[1].split(',').each {
            vertex.addEdge(Direction.OUT, 'linkedTo', Long.valueOf(it));
        }
    }
  return true;
}