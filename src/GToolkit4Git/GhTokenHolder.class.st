"
I am GhTokenHolder, I hold a GitHub Personal Access Token.

https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

https://github.com/settings/tokens

Tokens have scopes, read:org and repo should be included.

Usage

GhTokenHolder readTokenFrom: FileLocator home / '.secrets' / 'gh_token.txt'
"
Class {
	#name : #GhTokenHolder,
	#superclass : #Object,
	#classVars : [
		'token'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #example }
GhTokenHolder class >> exampleFromFile [
	<gtExample>
	
	| filePath |
	
	filePath := FileLocator home / '.secrets' / 'gh_token.txt'.

	self readTokenFrom: filePath.
	
	self assert: self hasToken.
	
	^ self token
]

{ #category : #testing }
GhTokenHolder class >> hasToken [
	^ self token notNil
]

{ #category : #initialization }
GhTokenHolder class >> readTokenFrom: aFileReference [
	self token: aFileReference asFileReference contents lines first.
	^ self token
]

{ #category : #accessing }
GhTokenHolder class >> token [
	^ token
]

{ #category : #initialization }
GhTokenHolder class >> token: aString [
	token := aString trimBoth
]
