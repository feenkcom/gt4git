"
I am GhTokenHolder, I hold a GitHub Personal Access Token.

https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

https://github.com/settings/tokens

Tokens have scopes, read:org and repo should be included.

I can be used in several ways:

- set my token directly from a string
- read and set/cache my token from a file
- set the file to read my token from each time it is needed

Note that in the first two usages the token is saved along with the image.
"
Class {
	#name : #GtGitHubTokenHolder,
	#superclass : #Object,
	#classVars : [
		'filePath',
		'token'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #initialization }
GtGitHubTokenHolder class >> clearToken [
	token := nil
]

{ #category : #example }
GtGitHubTokenHolder class >> exampleReadAndCacheTokenFromFile [
	<gtExample>
	<noTest>

	| exampleFilePath |

	exampleFilePath := FileLocator home / '.secrets' / 'gh_token.txt'.

	self clearToken.

	self readAndCacheTokenFrom: exampleFilePath.

	self assert: self hasToken.

	^ self token
]

{ #category : #example }
GtGitHubTokenHolder class >> exampleReadTokenEachTimeFromFile [
	<gtExample>
	<noTest>

	| exampleFilePath |

	exampleFilePath := FileLocator home / '.secrets' / 'gh_token.txt'.

	self clearToken.

	self readTokenEachTimeFrom: exampleFilePath.

	self assert: self hasToken.

	^ self token
]

{ #category : #testing }
GtGitHubTokenHolder class >> hasToken [
	^ self token isEmptyOrNil not
]

{ #category : #initialization }
GtGitHubTokenHolder class >> readAndCacheTokenFrom: aFileReference [
	"Read and set my token from aFileReference.
	Note that this also means the token will be saved along with the image"

	self token: aFileReference asFileReference contents lines first
]

{ #category : #initialization }
GtGitHubTokenHolder class >> readTokenEachTimeFrom: aFileReference [
	"Set the file from which I will read the token to aFileReference.
	Note that the token will not be saved along with the image, but read every time it is needed."
	
	filePath := aFileReference asFileReference
]

{ #category : #accessing }
GtGitHubTokenHolder class >> token [
	"Return the token that I hold, either as set directly or read from a file each time"
	
	token ifNotNil: [ ^ token ].
	
	(filePath notNil and: [ filePath exists ])
		ifTrue: [ ^ filePath contents lines first trimBoth ].
	
	^ nil
]

{ #category : #initialization }
GtGitHubTokenHolder class >> token: aString [
	"Set the token that I hold to aString.
	Note that this also means the token will be saved along with the image"

	token := aString trimBoth
]
