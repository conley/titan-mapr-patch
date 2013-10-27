import com.thinkaurelius.faunus.FaunusVertex
import com.tinkerpop.blueprints.Graph
import com.tinkerpop.blueprints.Vertex
import org.apache.hadoop.mapreduce.Mapper

import static com.thinkaurelius.faunus.formats.BlueprintsGraphOutputMapReduce.Counters.*
import static com.thinkaurelius.faunus.formats.BlueprintsGraphOutputMapReduce.LOGGER

def Vertex getOrCreateVertex(final FaunusVertex faunusVertex, final Graph graph, final Mapper.Context context) {
    final String uniqueKey = "name";
    final Object uniqueValue = faunusVertex.getProperty(uniqueKey);
    final Vertex blueprintsVertex;
    if (null == uniqueValue)
        throw new RuntimeException("The provided Faunus vertex does not have a property for the unique key: " + faunusVertex);

    final Iterator<Vertex> itty = graph.query().has(uniqueKey, uniqueValue).vertices().iterator();
    if (itty.hasNext()) {
        blueprintsVertex = itty.next();
        context.getCounter(VERTICES_RETRIEVED).increment(1l);
        if (itty.hasNext()) {
            LOGGER.error("The unique key is not unique as more than one vertex with the value: " + uniqueValue);
        }
    } else {
        blueprintsVertex = graph.addVertex(faunusVertex.getIdAsLong());
        context.getCounter(VERTICES_WRITTEN).increment(1l);
    }

    for (final String property : faunusVertex.getPropertyKeys()) {
        blueprintsVertex.setProperty(property, faunusVertex.getProperty(property));
        context.getCounter(VERTEX_PROPERTIES_WRITTEN).increment(1l);
    }
    return blueprintsVertex;
}