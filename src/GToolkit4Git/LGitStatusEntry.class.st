Class {
	#name : #LGitStatusEntry,
	#superclass : #LGitExternalStructure,
	#classVars : [
		'OFFSET_PRIM_HEAD_TO_INDEX',
		'OFFSET_PRIM_INDEX_TO_WORKDIR',
		'OFFSET_PRIM_STATUS'
	],
	#category : #'GToolkit4Git-NonCoreObjects'
}

{ #category : #'fields description' }
LGitStatusEntry class >> fieldsDesc [
	^ #(
		LGitStatusEnum status;
		LGitDiffDelta* head_to_index;
		LGitDiffDelta* index_to_workdir;
	)
]

{ #category : #accessing }
LGitStatusEntry >> gtInfoFor: aView [
	<gtView>
	^ ({
		#HeadToIndex -> self prim_head_to_index.
		#IndexToWorkdir -> self prim_index_to_workdir.
		#Status -> self prim_status.
	} asOrderedDictionary gtItemsFor: aView)
			title: 'Info';
			priority: 3
]

{ #category : #'libgit-fields' }
LGitStatusEntry >> prim_head_to_index [
	"This method was automatically generated"
	^LGitDiffDelta fromHandle: (handle pointerAt: OFFSET_PRIM_HEAD_TO_INDEX)
]

{ #category : #'libgit-fields' }
LGitStatusEntry >> prim_head_to_index: anObject [
	"This method was automatically generated"
	handle pointerAt: OFFSET_PRIM_HEAD_TO_INDEX put: anObject getHandle.
]

{ #category : #'libgit-fields' }
LGitStatusEntry >> prim_index_to_workdir [
	"This method was automatically generated"
	^LGitDiffDelta fromHandle: (handle pointerAt: OFFSET_PRIM_INDEX_TO_WORKDIR)
]

{ #category : #'libgit-fields' }
LGitStatusEntry >> prim_index_to_workdir: anObject [
	"This method was automatically generated"
	handle pointerAt: OFFSET_PRIM_INDEX_TO_WORKDIR put: anObject getHandle.
]

{ #category : #'libgit-fields' }
LGitStatusEntry >> prim_status [
	"This method was automatically generated"
	^LGitStatusEnum fromInteger: (handle unsignedLongAt: OFFSET_PRIM_STATUS)
]

{ #category : #'libgit-fields' }
LGitStatusEntry >> prim_status: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_PRIM_STATUS put: anObject value
]
