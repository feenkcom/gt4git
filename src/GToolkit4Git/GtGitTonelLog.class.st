Class {
	#name : #GtGitTonelLog,
	#superclass : #IceLibgitTonelLog,
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
GtGitTonelLog >> collectCommitsFor: aMethod path: aPath [
	| commits |
	commits := repository revListForCommit: repository headCommit id andPath: aPath.
	^ commits collect: [ :each | repository commitFromGitCommit: each ]
]
