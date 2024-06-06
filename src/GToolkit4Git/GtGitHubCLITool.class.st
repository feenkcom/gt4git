"
I am GtGitHubCLITool.

I am a wrapper around the GitHub CLI tool gh.

See https://cli.github.com/

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
	| output |
	output := self ghProcessBuilder
		args: #('auth' 'token');
		output.
	^ output status isSuccess
		ifTrue: [ output stdout ]
		ifFalse: [ self error: 'gh auth token failed: ' , output stderr ]
]

{ #category : #private }
GtGitHubCLITool >> ghProcessBuilder [
	^ GtExternalProcessBuilder new
		workingDirectory: self workingDirectory;
		env: 'GH_TOKEN' value: token;
		command: 'gh';
		yourself
]

{ #category : #accessing }
GtGitHubCLITool >> repositoryList [
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

{ #category : #accessing }
GtGitHubCLITool >> workingDirectory [
	^ workingDirectory
]

{ #category : #initialization }
GtGitHubCLITool >> workingDirectory: aFileReference [
	workingDirectory := aFileReference
]
