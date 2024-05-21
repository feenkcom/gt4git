Class {
	#name : #GitCliTonelLog,
	#superclass : #IceLibgitTonelLog,
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
GitCliTonelLog >> collectCommitsFor: aMethod path: aPath [
	| commits |
	commits := repository revListForCommit: repository headCommit id andPath: aPath.
	^ commits collect: [ :each | repository commitFromGitCommit: each ]
]

{ #category : #accessing }
GitCliTonelLog >> collectVersionsFrom: aCollection method: aMethod path: aPath [
	| lastDefinition basepath history |
		
	basepath := self basepathOf: aPath.
	lastDefinition := MCMethodDefinition new.
	history := OrderedCollection new.
	aCollection reverseDo: [ :eachCommit | | definition |
		definition := self definitionFor: aMethod path: basepath commit: eachCommit.
		lastDefinition = definition  ifFalse: [ 
			history add: (IceLogVersion 
				commit: eachCommit
				definition: definition asRingDefinition).
			lastDefinition := definition ] ].

	^ history reversed
]
