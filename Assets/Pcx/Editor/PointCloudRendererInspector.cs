// Pcx - Point cloud importer & renderer for Unity
// https://github.com/keijiro/Pcx

using UnityEngine;
using UnityEditor;

namespace Pcx
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(PointCloudRenderer))]
    public class PointCloudRendererInspector : Editor
    {
        SerializedProperty _sourceData;
        SerializedProperty _pointTint;
        SerializedProperty _pointSize;
        SerializedProperty _gradient;

        void OnEnable()
        {
            _sourceData = serializedObject.FindProperty("_sourceData");
            _pointTint = serializedObject.FindProperty("_pointTint");
            _pointSize = serializedObject.FindProperty("_pointSize");
            _gradient = serializedObject.FindProperty("_gradient");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.PropertyField(_sourceData);
            EditorGUILayout.PropertyField(_pointTint);
            EditorGUILayout.PropertyField(_pointSize);
            EditorGUILayout.PropertyField(_gradient);

            PointCloudRenderer renderer = (PointCloudRenderer)target;

            if (GUILayout.Button("Generate"))
            {
                renderer.GenerateRandom();
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}
