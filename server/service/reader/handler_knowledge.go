package reader

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
)

// @Summary Get knowledge graph data
// @Description Returns concept tags and edges for the current user's knowledge network
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param book_id query string false "Filter by book ID"
// @Success 200 {object} map[string]interface{}
// @Failure 500 {object} schema.ErrorResponse
// @Router /reader/knowledge [get]
func GetKnowledgeGraph(c *gin.Context) {
	userID := c.GetInt64("userID")
	bookID := c.Query("book_id")

	db := store.FileStore()

	var tags []schema.ConceptTag
	var err error
	if bookID != "" {
		tags, err = schema.ListConceptTagsByBook(db, userID, bookID)
	} else {
		tags, err = schema.ListConceptTags(db, userID)
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	edges, err := schema.ListConceptEdges(db, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"nodes": tags,
		"edges": edges,
	})
}

// @Summary Sync concept tags
// @Description Bulk upsert concept tags from client
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param body body []schema.ConceptTag true "Concept tags"
// @Success 200 {object} map[string]string
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/knowledge/tags [post]
func SyncConceptTags(c *gin.Context) {
	userID := c.GetInt64("userID")

	var tags []schema.ConceptTag
	if err := c.ShouldBindJSON(&tags); err != nil {
		c.JSON(http.StatusBadRequest, schema.ErrorResponse{Message: err.Error()})
		return
	}

	for i := range tags {
		tags[i].UserID = userID
	}

	if err := schema.UpsertConceptTags(store.FileStore(), tags); err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// @Summary Sync concept edges
// @Description Bulk upsert concept edges from client
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param body body []schema.ConceptEdge true "Concept edges"
// @Success 200 {object} map[string]string
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/knowledge/edges [post]
func SyncConceptEdges(c *gin.Context) {
	userID := c.GetInt64("userID")

	var edges []schema.ConceptEdge
	if err := c.ShouldBindJSON(&edges); err != nil {
		c.JSON(http.StatusBadRequest, schema.ErrorResponse{Message: err.Error()})
		return
	}

	for i := range edges {
		edges[i].UserID = userID
	}

	if err := schema.UpsertConceptEdges(store.FileStore(), edges); err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
