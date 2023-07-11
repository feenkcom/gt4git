Class {
	#name : #GtIceCommitWalk,
	#superclass : #IceAbstractCommitWalk,
	#instVars : [
		'ids'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #walking }
GtIceCommitWalk >> commitsDo: aBlock [
	(repository commitsFromIds: ids) do: [ :each | aBlock value: each ]
]

{ #category : #'walk definition' }
GtIceCommitWalk >> fromBranch: branch [
	ids := repository revListForBranch: branch
]

{ #category : #walking }
GtIceCommitWalk >> rawResultsDo: aBlock [
	ids do: [ :each | aBlock value: each ]
]