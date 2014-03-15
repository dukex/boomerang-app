package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	//	auth "github.com/dukex/login2"
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

var (
	ASSETS_VERSION string
	ENV            string
	PORT           string
	URL            string
	PAGES          map[string][]byte
)

func getGitSHA() string {
	cmd := exec.Command("git", "rev-parse", "HEAD")
	var out bytes.Buffer
	cmd.Stdout = &out
	err := cmd.Run()
	if err != nil {
		log.Fatal(err)
	}
	sha := out.String()
	sha = strings.Replace(sha, "\n", "", -1)
	return sha
}

func buildPage(page string) string {
	var pageBytes []byte

	if ENV == "development" {
		pageBytes = getBytes(page)
	}

	pageBytes, ok := PAGES[page]

	if !ok {
		pageBytes = getBytes(page)
	}

	pageHTML := string(pageBytes[:])
	pageHTML = strings.Replace(pageHTML, "<% URL %>", URL, -1)
	pageHTML = strings.Replace(pageHTML, "<% ASSETS_VERSION %>", ASSETS_VERSION, -1)

	return pageHTML
}

func getBytes(page string) []byte {
	pageBytes, _ := ioutil.ReadFile("./views/" + page + ".html")
	PAGES[page] = pageBytes
	return pageBytes
}

func respondWith(page string) func(w http.ResponseWriter, request *http.Request) {
	return func(w http.ResponseWriter, request *http.Request) {
		fmt.Fprintf(w, buildPage(page))
	}
}

func main() {
	ASSETS_VERSION = getGitSHA()
	ENV = os.Getenv("ENV")
	PORT = os.Getenv("PORT")
	URL = os.Getenv("URL")

	PAGES = make(map[string][]byte, 0)

	r := mux.NewRouter()
	r.StrictSlash(true)

	r.HandleFunc("/", respondWith("landing"))
	r.HandleFunc("/podurl", respondWith("podurl"))
	r.HandleFunc("/oauth", respondWith("oauth"))
	r.HandleFunc("/bookmark", respondWith("bookmark"))

	r.PathPrefix("/").Handler(http.FileServer(http.Dir("./public/")))

	h := handlers.LoggingHandler(os.Stdout, r)

	http.Handle("/", h)
	server := &http.Server{
		Addr:           ":" + PORT,
		Handler:        h,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}

	fmt.Println("Starting server on", PORT)
	log.Fatal(server.ListenAndServe())
}
