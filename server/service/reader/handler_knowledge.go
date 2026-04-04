package reader

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
)

// @Summary Get knowledge graph data
// @Description Returns concept tags and edges for the current user's knowledge network
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param book_id query string false "Filter by book ID"
// @Param since query int false "Delta sync: only return records with ctime > since (milliseconds)"
// @Success 200 {object} object{nodes=[]schema.ConceptTag,edges=[]schema.ConceptEdge,server_time=int64} "Knowledge graph with server timestamp"
// @Failure 500 {object} schema.ErrorResponse
// @Router /reader/knowledge [get]
func GetKnowledgeGraph(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	bookID := c.Query("book_id")

	db := store.FileStore()

	var since int64
	if sinceStr := c.Query("since"); sinceStr != "" {
		if s, err := strconv.ParseInt(sinceStr, 10, 64); err == nil && s > 0 {
			since = s
		}
	}

	var tags []schema.ConceptTag
	var err error
	if since > 0 {
		if bookID != "" {
			tags, err = schema.ListConceptTagsByBookSince(db, userID, bookID, since)
		} else {
			tags, err = schema.ListConceptTagsSince(db, userID, since)
		}
	} else {
		if bookID != "" {
			tags, err = schema.ListConceptTagsByBook(db, userID, bookID)
		} else {
			tags, err = schema.ListConceptTags(db, userID)
		}
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	var edges []schema.ConceptEdge
	if since > 0 {
		edges, err = schema.ListConceptEdgesSince(db, userID, since)
	} else {
		edges, err = schema.ListConceptEdges(db, userID)
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"nodes":       tags,
		"edges":       edges,
		"server_time": time.Now().UnixMilli(),
	})
}

// @Summary Sync concept tags
// @Description Bulk upsert concept tags from client, returns server-assigned ID mappings
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param body body []schema.ConceptTagWithLocalID true "Concept tags with optional local_id"
// @Success 200 {object} object{status=string,mappings=[]object{local_id=int,server_id=int}} "Sync result with ID mappings"
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/knowledge/tags [post]
func SyncConceptTags(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var tags []schema.ConceptTagWithLocalID
	if err := c.ShouldBindJSON(&tags); err != nil {
		c.JSON(http.StatusBadRequest, schema.ErrorResponse{Message: err.Error()})
		return
	}

	for i := range tags {
		tags[i].UserID = userID
	}

	mappings, err := schema.UpsertConceptTagsWithMapping(store.FileStore(), tags)
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   "ok",
		"mappings": mappings,
	})
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
	userID := c.GetInt64(middleware.XUserIDTag)

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
