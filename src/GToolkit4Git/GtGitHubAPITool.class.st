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
GtGitHubAPITool >> createPullRequestRepositoryOwner: owner name: repositoryName branch: branchName title: title body: body [
]

{ #category : #operations }
GtGitHubAPITool >> forkRepositoryOwner: owner name: repositoryName [
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
		setBearerAuthentication: token
]

{ #category : #initialization }
GtGitHubAPITool >> token: aGitHubToken [
	token := aGitHubToken
]

{ #category : #operations }
GtGitHubAPITool >> user [
	"Return the authenticated user"

	^ self restClient
		get: 'https://api.github.com/user'
]
