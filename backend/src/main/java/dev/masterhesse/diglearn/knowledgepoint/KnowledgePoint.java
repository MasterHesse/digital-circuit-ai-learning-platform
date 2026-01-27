package dev.masterhesse.diglearn.knowledgepoint;

import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;

@Node("KnowledgePoint")
public class KnowledgePoint {
    
    @Id
    private String kpId;

    private String title;
    private String category;
    private Integer difficulty;

    public KnowledgePoint() {}

    public String getKpId() {return kpId;}
    public void setKpId(String kpId) {this.kpId = kpId;}

    public String getTitle() {return title;}
    public void setTitle(String title) {this.title = title;}

    public String getCategory() {return category;}
    public void setCategory(String category) {this.category = category;}

    public Integer getDifficulty() {return difficulty;}
    public void setDifficulty(Integer difficulty) {this.difficulty = difficulty;}

}
