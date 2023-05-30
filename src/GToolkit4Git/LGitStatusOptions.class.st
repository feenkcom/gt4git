Class {
	#name : #LGitStatusOptions,
	#superclass : #LGitExternalStructure,
	#instVars : [
		'statusOptionsVersion'
	],
	#classVars : [
		'OFFSET_PRIM_BASELINE',
		'OFFSET_PRIM_FLAGS',
		'OFFSET_PRIM_PATHSPEC',
		'OFFSET_PRIM_SHOW',
		'OFFSET_PRIM_VERSION'
	],
	#category : #'GToolkit4Git-NonCoreObjects'
}

{ #category : #'field definition' }
LGitStatusOptions class >> fieldsDesc [
	^ #(
		uint32 version
		uint32 show
		LGitStatusOptionEnum flags
		LGitStringArray pathspec
		LGitTree baseline
	)
]

{ #category : #accessing }
LGitStatusOptions >> add: aStatusOptionsEnum [
	handle unsignedLongAt: OFFSET_PRIM_FLAGS put: (aStatusOptionsEnum value bitOr: self prim_flags value)
]

{ #category : #accessing }
LGitStatusOptions >> gtInfoFor: aView [

	<gtView>
	^ ({ 
		   (#Pathspec -> self prim_pathspec).
		   (#Version -> self prim_version).
		   (#Flags -> self prim_flags) } asOrderedDictionary gtItemsFor:
			   aView)
		  title: 'Info';
		  priority: 7
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_baseline [
	"This method was automatically generated"
	^ExternalData fromHandle: (handle pointerAt: OFFSET_PRIM_BASELINE) type: ExternalType void asPointerType
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_baseline: anObject [
	"This method was automatically generated"
	handle pointerAt: OFFSET_PRIM_BASELINE put: anObject getHandle.
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_flags [
	"This method was automatically generated"
	^LGitStatusOptionEnum fromInteger: (handle unsignedLongAt: OFFSET_PRIM_FLAGS)
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_flags: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_PRIM_FLAGS put: anObject value
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_pathspec [
	"This method was automatically generated"
	^ LGitStringArray fromHandle: (handle referenceStructAt: OFFSET_PRIM_PATHSPEC length: LGitStringArray byteSize)
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_pathspec: anObject [
	"This method was automatically generated"
	handle structAt: OFFSET_PRIM_PATHSPEC put: anObject getHandle length: LGitStringArray byteSize
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_show [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_PRIM_SHOW
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_show: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_PRIM_SHOW put: anObject
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_version [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_PRIM_VERSION
]

{ #category : #'libgit-fields' }
LGitStatusOptions >> prim_version: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_PRIM_VERSION put: anObject
]

{ #category : #'instance creation' }
LGitStatusOptions >> statusOptionsInit [
	statusOptionsVersion := 1.
	self status_options_init
]

{ #category : #'instance creation' }
LGitStatusOptions >> status_options_init [
	self ffiCallSafely: #(int git_status_options_init(self, int statusOptionsVersion)) options: #()
]
