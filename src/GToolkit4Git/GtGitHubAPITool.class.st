"
I am GtGitHubAPITool.

I am a wrapper around the GitHub REST API.

See https://docs.github.com/en/rest

I need a personal access token to work.
"
Class {
	#name : #GtGitHubAPITool,
	#superclass : #Object,
	#instVars : [
		'token'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #operations }
GtGitHubAPITool >> createPullRequestBy: forkOwner forRepositoryOwner: sourceOwner name: repositoryName branch: branchName description: description [
	"Create a pull request from the repository forkOwner/repositoryName:branchName
	to the parent/source from which it was forked, targetting main, sourceOwner/repositoryName:main.
	Use description for the title and body."

	^ self restClient
		url: 'https://api.github.com/repos';
		addPathSegment: sourceOwner;
		addPathSegment: repositoryName;
		addPathSegment: 'pulls';
		contents: {
			#title -> description lines first.
			#body -> description.
			#head_repo -> forkOwner.
			#head -> (forkOwner , ':' , branchName).
			#base -> 'main' } asDictionary;
		post
]

{ #category : #operations }
GtGitHubAPITool >> forkRepositoryOwner: owner name: repositoryName [
	"Create a fork of the repository owner/repositoryName in the user's account"

	^ self restClient
		url: 'https://api.github.com/repos';
		addPathSegment: owner;
		addPathSegment: repositoryName;
		addPathSegment: 'forks';
		contents: {
			#name -> repositoryName.
			#'default_branch_only' -> true } asDictionary;
		post
]

{ #category : #initialization }
GtGitHubAPITool >> readTokenFrom: aFileReference [
	self token: aFileReference asFileReference contents lines first
]

{ #category : #operations }
GtGitHubAPITool >> repositoryList [
	"Return a list of the user's repositories, limited to 100."

	^ self restClient
		url: 'https://api.github.com/user/repos';
		queryAt: 'per_page' add: '100';
		get
]

{ #category : #operations }
GtGitHubAPITool >> repositoryOwner: owner name: repositoryName [
	"Return the repository owner/repositoryName"
	
	^ self restClient
		url: 'https://api.github.com/repos';
		addPathSegment: owner;
		addPathSegment: repositoryName;
		get
]

{ #category : #private }
GtGitHubAPITool >> restClient [
	^ ZnClient new
		forJsonREST;
		setBearerAuthentication: self token
]

{ #category : #accessing }
GtGitHubAPITool >> token [
	^ token ifNil: [ GhTokenHolder token ]
]

{ #category : #initialization }
GtGitHubAPITool >> token: aGitHubToken [
	token := aGitHubToken trimBoth
]

{ #category : #operations }
GtGitHubAPITool >> user [
	"Return the authenticated user"

	^ self restClient
		get: 'https://api.github.com/user'
]
