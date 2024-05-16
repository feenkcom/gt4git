Class {
	#name : #GtIceCommitWalk,
	#superclass : #IceAbstractCommitWalk,
	#instVars : [
		'ids'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
GtIceCommitWalk >> commitStream [
	^ (repository commitsFromIds: ids) asAsyncStream
]

{ #category : #walking }
GtIceCommitWalk >> commitsDo: aBlock [
	(repository commitsFromIds: ids) do: [ :each | aBlock value: each ]
]

{ #category : #'walk definition' }
GtIceCommitWalk >> fromBranch: branch [
	ids := repository revListForBranch: branch
]

{ #category : #'walk definition' }
GtIceCommitWalk >> fromCommit: commit [
	ids := repository revListForCommit: commit id
]

{ #category : #'walk definition' }
GtIceCommitWalk >> fromTag: tag [
	ids := repository revListForBranch: tag
]

{ #category : #accessing }
GtIceCommitWalk >> ids [
	^ids
]

{ #category : #walking }
GtIceCommitWalk >> rawResultsDo: aBlock [
	ids do: [ :each | aBlock value: each ]
]

{ #category : #'walk definition' }
GtIceCommitWalk >> uptoCommit: commit [
	ids := ids copyWithoutAll: commit newCommitWalk ids asSet.
]
