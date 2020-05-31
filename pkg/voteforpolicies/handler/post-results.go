package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/VJftw/vote-for-policies/pkg/voteforpolicies/result"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (h *Handler) PostResults(c *gin.Context) {
	err := c.Request.ParseForm()
	if err != nil {
		log.Println(err)
	}

	id, err := uuid.NewRandom()
	if err != nil {
		log.Println(err)
	}

	res := &result.Result{
		ID:       id.String(),
		Party:    map[result.Party]uint{},
		Category: map[result.Category]result.Party{},
	}

	for k, v := range c.Request.PostForm {
		category := result.Category(k)
		party := result.Party(v[0])

		res.Category[category] = party

		if _, ok := res.Party[party]; !ok {
			res.Party[party] = 0
		}
		res.Party[party]++
	}

	if err := h.storage.Save(res); err != nil {
		log.Println(err)
		c.JSON(500, err)
		return
	}

	// TODO: render

	// push to s3
	jsonBytes, err := json.Marshal(res)
	if err != nil {
		log.Println(err)
	}
	body := strings.NewReader(string(jsonBytes))
	keyPath, err := h.origin.Save(fmt.Sprintf("%s/index.html", res.ID), body)
	if err != nil {
		log.Println(err)
		c.JSON(500, err)
		return
	}

	// redirect
	c.Redirect(http.StatusSeeOther, fmt.Sprintf("%s%s", h.originAddress, keyPath))
}
