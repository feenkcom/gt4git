Class {
	#name : #LGitStatusEnum,
	#superclass : #LGitExternalEnumerationUInt32,
	#category : #'GToolkit4Git-NonCoreObjects'
}

{ #category : #'enum declaration' }
LGitStatusEnum class >> enumDecl [

	^ #(
		GIT_STATUS_CURRENT 0
		GIT_STATUS_INDEX_NEW 1
	    GIT_STATUS_INDEX_MODIFIED 2
	    GIT_STATUS_INDEX_DELETED 4
	    GIT_STATUS_INDEX_RENAMED 8
	    GIT_STATUS_INDEX_TYPECHANGE 16
	    GIT_STATUS_WT_NEW 128
	    GIT_STATUS_WT_MODIFIED 256
	    GIT_STATUS_WT_DELETED 512
	    GIT_STATUS_WT_TYPECHANGE 1024
	    GIT_STATUS_WT_RENAMED 2048
	    GIT_STATUS_WT_UNREADABLE 4096
	    GIT_STATUS_IGNORED 16384
	    GIT_STATUS_CONFLICTED 32768
	   )
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_conflicted [
	^ self basicNew
		value: 32768;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_current [
	^ self basicNew
		value: 0;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_ignored [
	^ self basicNew
		value: 16384;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_index_deleted [
	^ self basicNew
		value: 4;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_index_modified [
	^ self basicNew
		value: 2;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_index_new [
	^ self basicNew
		value: 1;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_index_renamed [
	^ self basicNew
		value: 8;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_index_typechange [
	^ self basicNew
		value: 16;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_wt_deleted [
	^ self basicNew
		value: 512;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_wt_modified [
	^ self basicNew
		value: 256;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_wt_new [
	^ self basicNew
		value: 128;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_wt_renamed [
	^ self basicNew
		value: 2048;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_wt_typechange [
	^ self basicNew
		value: 1024;
		yourself
]

{ #category : #'accessing - values' }
LGitStatusEnum class >> git_status_wt_unreadable [
	^ self basicNew
		value: 4096;
		yourself
]

{ #category : #accessing }
LGitStatusEnum >> categoryName [

	^ self isStaged
		ifTrue: [ 'Staged' ]
		ifFalse: [ 
			self isTracked
				ifTrue: [ 'Not Staged' ]
				ifFalse: [ 'Untracked' ] ]
]

{ #category : #accessing }
LGitStatusEnum >> isStaged [
	^ self value between: 1 and: 127
]

{ #category : #accessing }
LGitStatusEnum >> isTracked [
	^ self isUnstaged or: [ self isStaged ]
]

{ #category : #accessing }
LGitStatusEnum >> isUnstaged [
	^ (self value between: 256 and: 4096)
]

{ #category : #accessing }
LGitStatusEnum >> statusName [

	self value = 0 ifTrue: [ ^ 'Current' ].
	(self value = 1 or: [ self value = 128 ]) ifTrue: [ ^ 'New' ].
	(self value = 2 or: [ self value = 256 ]) ifTrue: [ ^ 'Modified' ].
	(self value = 4 or: [ self value = 512 ]) ifTrue: [ ^ 'Deleted' ].
	(self value = 8 or: [ self value = 2048 ]) ifTrue: [ ^ 'Renamed' ].
	(self value = 16 or: [ self value = 1024 ]) ifTrue: [ 
		^ 'Type Changed' ].
	self value = 4096 ifTrue: [ ^ 'Unreadable' ].
	self value = 16384 ifTrue: [ ^ 'Ignored' ].
	self value = 32768 ifTrue: [ ^ 'Conflicted' ].
	^ self symbol
]
