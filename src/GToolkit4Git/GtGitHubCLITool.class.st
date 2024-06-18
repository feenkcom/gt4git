"
I am GtGitHubCLITool.

I am a wrapper around the GitHub CLI tool gh.

See https://cli.github.com/

I need a personal access token to work.

You should set my working directory to an on-disk git repository.

"
Class {
	#name : #GtGitHubCLITool,
	#superclass : #Object,
	#instVars : [
		'token',
		'workingDirectory'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #operations }
GtGitHubCLITool >> authToken [
	"Return the authentication token being used.
	This effectively verifies if the token was set correctly."

	| output |
	output := self ghProcessBuilder
		args: #('auth' 'token');
		output.
	^ output status isSuccess
		ifTrue: [ output stdout ]
		ifFalse: [ self error: 'gh auth token failed: ' , output stderr ]
]

{ #category : #operations }
GtGitHubCLITool >> createPullRequest [
	"Create a pull request based on the current feature branch of
	the forked repository in the working directory"

	| output |
	output := self ghProcessBuilder
		args: #('pr' 'create' '--fill');
		output.
	^ output status isSuccess
		ifTrue: [ output stdout ]
		ifFalse: [ self error: 'gh pr create failed: ' , output stderr ]
]

{ #category : #operations }
GtGitHubCLITool >> forkRepository [
	"Fork the repository in the working directory"

	| output |
	output := self ghProcessBuilder
		args: #('repo' 'fork' '--remote' '--clone');
		output.
	^ output status isSuccess
		ifTrue: [ true ]
		ifFalse: [ self error: 'gh repo fork failed: ' , output stderr ]
]

{ #category : #private }
GtGitHubCLITool >> ghProcessBuilder [
	^ GtExternalProcessBuilder new
		workingDirectory: self workingDirectory;
		env: 'GH_TOKEN' value: token;
		command: 'gh';
		yourself
]

{ #category : #initialization }
GtGitHubCLITool >> readTokenFrom: aFileReference [
	self token: aFileReference asFileReference contents lines first
]

{ #category : #operations }
GtGitHubCLITool >> repository [
	"Return the repository pointed to by the working directory,
	assuming it follows the owner/repo naming convention"
	
	| output uri |
	uri := 'https://api.github.com/repos/{1}/{2}' format: { 
		self workingDirectory path segments allButLast last . 
		self workingDirectory path segments last }. 
	output := self ghProcessBuilder
		args: { 'api' . uri };
		output.
	^ output status isSuccess
		ifTrue: [ NeoJSONObject fromString: output stdout ]
		ifFalse: [ self error: 'gh api ' , uri , ' failed: ' , output stderr ]
]

{ #category : #operations }
GtGitHubCLITool >> repositoryList [
	"Return a list of the user's repositories, limited to 100."

	| output |
	output := self ghProcessBuilder
		args: #('repo' 'ls' '--json' 'nameWithOwner,description,url' '--limit' '100');
		output.
	^ output status isSuccess
		ifTrue: [ NeoJSONObject fromString: output stdout ]
		ifFalse: [ self error: 'gh repo ls failed: ' , output stderr ]
]

{ #category : #initialization }
GtGitHubCLITool >> token: aGitHubToken [
	token := aGitHubToken
]

{ #category : #operations }
GtGitHubCLITool >> user [
	"Return the authenticated user"

	| output |
	output := self ghProcessBuilder
		args: #('api' 'https://api.github.com/user');
		output.
	^ output status isSuccess
		ifTrue: [ NeoJSONObject fromString: output stdout ]
		ifFalse: [ self error: 'gh api https://api.github.com/user failed: ' , output stderr ]
]

{ #category : #operations }
GtGitHubCLITool >> version [
	"Return gh command line tool version information.
	This needs no token, nor working directory to be set."
	
	<gtExample>
	^ (GtExternalProcessBuilder new
		command: 'gh';
		args: #('--version');
		output) stdout
]

{ #category : #accessing }
GtGitHubCLITool >> workingDirectory [
	^ workingDirectory ifNil: [ FileLocator workingDirectory ]
]

{ #category : #initialization }
GtGitHubCLITool >> workingDirectory: aFileReference [
	workingDirectory := aFileReference
]
