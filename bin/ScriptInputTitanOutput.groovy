import com.thinkaurelius.faunus.FaunusVertex

import static com.tinkerpop.blueprints.Direction.OUT

def boolean read(FaunusVertex vertex, String line) {
	
	fieldNames = [ 
	"domainName",
	"registrarName",
	"contactEmail",
	"whoisServer",
	"nameServers",
	"createdDate",
	"updatedDate",
	"expiresDate",
	"standardRegCreatedDate",
	"standardRegUpdatedDate",
	"standardRegExpiresDate",
	"status",
	"Audit_auditUpdatedDate",
	"registrant_email",
	"registrant_name",
	"registrant_organization",
	"registrant_street1",
	"registrant_street2",
	"registrant_street3",
	"registrant_street4",
	"registrant_city",
	"registrant_state",
	"registrant_postalCode",
	"registrant_country",
	"registrant_fax",
	"registrant_faxExt",
	"registrant_telephone",
	"registrant_telephoneExt",
	"administrativeContact_email",
	"administrativeContact_name",
	"administrativeContact_organization",
	"administrativeContact_street1",
	"administrativeContact_street2",
	"administrativeContact_street3",
	"administrativeContact_street4",
	"administrativeContact_city",
	"administrativeContact_state",
	"administrativeContact_postalCode",
	"administrativeContact_country",
	"administrativeContact_fax",
	"administrativeContact_faxExt",
	"administrativeContact_telephone",
	"administrativeContact_telephoneExt" 
	]
	
    parts = line.split('\001');
    vertex.reuse(Long.valueOf(parts[0]))
    if (parts.length == 2) {
        parts[1].split(',').each {
            vertex.addEdge(Direction.OUT, 'linkedTo', Long.valueOf(it));
        }
    }
  return true;
}